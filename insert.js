const mysql = require('mysql');
const fs = require('fs'); // For reading the JSON file

// Create a MySQL connection
const connection = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "Meryem1999!Txf5opkiT:a0kj",
  database: "rafvue",
});

// Load JSON data from file
const data = JSON.parse(fs.readFileSync('parsed_data2.json', 'utf-8'));
const stData = data.filter(item => item.hasOwnProperty('SubmitterInformation'));
console.log(data.length);

// Function to insert ISA record
function insertISARecord(isaData) {
  return new Promise((resolve, reject) => {
    connection.query('INSERT INTO ISA SET ?', isaData, (error, results) => {
      if (error) {
        reject(error);
      } else {
        resolve(results.insertId);
      }
    });
  });
}

// Function to insert Transaction record
function insertTransactionRecord(transactionData, isaId) {
  return new Promise((resolve, reject) => {
    connection.query('INSERT INTO Transaction SET ?, isa_id = ?', [transactionData, isaId], (error, results) => {
      if (error) {
        reject(error);
      } else {
        resolve(results.insertId);
      }
    });
  });
}

// Function to insert Submitter, Receiver, BillingProvider records
function insertRelatedRecords(transactionId, submitterData, receiverData, billingProviderData) {
  return new Promise((resolve, reject) => {
    connection.beginTransaction((error) => {
      if (error) {
        reject(error);
      } else {
        // Insert Submitter
        connection.query('INSERT INTO Submitter SET ?, transaction_id = ?', [submitterData, transactionId], (error) => {
          if (error) {
            connection.rollback(() => reject(error));
          } else {
            // Insert Receiver
            connection.query('INSERT INTO Receiver SET ?, transaction_id = ?', [receiverData, transactionId], (error) => {
              if (error) {
                connection.rollback(() => reject(error));
              } else {
                // Insert BillingProvider
                connection.query('INSERT INTO BillingProvider SET ?, transaction_id = ?', [billingProviderData, transactionId], (error) => {
                  if (error) {
                    connection.rollback(() => reject(error));
                  } else {
                    connection.commit((error) => {
                      if (error) {
                        connection.rollback(() => reject(error));
                      } else {
                        resolve();
                      }
                    });
                  }
                });
              }
            });
          }
        });
      }
    });
  });
}

// Loop through each ISA record
async function processISARecords() {
  for (const isaData of data) {
    try {
      // Insert ISA record
      const isaId = await insertISARecord(isaData.ISA);

      // Insert Transaction record
      const transactionId = await insertTransactionRecord(isaData.Transaction, isaId);

      // Insert related Submitter, Receiver, BillingProvider records
      await insertRelatedRecords(transactionId, isaData.Submitter, isaData.Receiver, isaData.BillingProvider);

      // Continue inserting other related records (Subscriber, Claims, etc.) here

    } catch (error) {
      console.error('Error inserting data:', error);
    }
  }

  // Close the MySQL connection
  connection.end();
}

// Start processing ISA records
//processISARecords();

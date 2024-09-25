const { PythonShell } = require('python-shell');

// Define the options for running the Python script
const options = {
  pythonPath: 'C:/Python/Python311/python.exe', // Use 'python3' or a specific Python executable if needed
  scriptPath: 'D:/rafvue', // Set the path to your Python script directory
  args: [] // Add any command line arguments if your Python script expects them
};

// Create a new PythonShell instance
const pyShell = new PythonShell('mysql_script.py', options);

// Handle Python script output (stdout)
pyShell.on('message', (message) => {
  console.log(message);
});

// Handle Python script completion
pyShell.end((err) => {
  if (err) {
    console.error(err);
  } else {
    console.log('Python script completed.');
  }
});

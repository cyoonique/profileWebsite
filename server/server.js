const path = require('path');
const express = require('express');
const bodyParser = require('body-parser');

const PORT = 3000;
const app = express();

// Bodyparser Middleware
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }))

// handle requests for static files
app.use('/assets', express.static(path.join(__dirname, '../src/assets')));

/**
 * define route handlers
 */
// within production environment, serve the frontend with bundle.js file
if (process.env.NODE_ENV === 'production') {
  // statically serve everything in the build folder on the route '/build'
  app.use('/build', express.static(path.resolve(__dirname, '../build')));
  // serve index.html on the route '/'
  app.get('/', (req, res) => {
    res.sendFile(path.resolve(__dirname, '../src/index.html'));
  });
};

// respond with main app
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '../src/index.html'))
});

// catch-all route handler for any requests to an unknown route
app.use((req, res) => res.sendStatus(404));

// Global error-handler
app.use((err, req, res, next) => {
    const defaultErr = {
      log: 'Express error handler caught unknown middleware error',
      status: 400,
      message: { err: 'An error occurred' },
    };
    const errorObj = Object.assign({}, defaultErr, err);
    console.log(errorObj.log);
    return res.status(errorObj.status).json(errorObj.message);
});

app.listen(PORT, () => {
  console.log(`Server listening on port: ${PORT}...`)
});

module.exports = app;
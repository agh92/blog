const express = require("express");

const cwd = process.cwd();

const port = 3080;

express()
  .use(express.static(cwd + "/blog/dist/"))
  .get("/", (req, res) => res.sendFile(cwd + "/blog/dist/index.html"))
  .listen(port, () => console.log(`Server listening on the port::${port}`));

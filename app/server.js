const express = require("express");
const app = express();

const PORT = process.env.PORT || 3000;
const COLOR = process.env.COLOR || "unknown";
const VERSION = process.env.VERSION || "1.0.0";

app.get("/", (req, res) => {
  res.send(`Welcome to the ${COLOR} app!`);
});

// Healthcheck & deployment route
app.get("/version", (req, res) => {
  res.json({
    version: VERSION,
    color: COLOR,
    status: "running",
  });
});

app.listen(PORT, () => {
  console.log(`✅ ${COLOR} app running on port ${PORT}`);
});

const express = require("express");
const path = require("path");

const app = express();

/* serve frontend */
app.use(express.static(path.join(__dirname, "public")));

app.get('/', (req, res) => {
  res.json({ message: "Hello from backend" });
});

/* API */
app.get("/api", (req, res) => {                                
  res.json({ message: "Hello from backend" });
});

/* fallback (important for React/SPA style routing) */
app.get("*", (req, res) => {
  res.sendFile(path.join(__dirname, "public", "index.html"));
});

app.listen(3000, "0.0.0.0", () => {
  console.log("Server running on port 3000");
});

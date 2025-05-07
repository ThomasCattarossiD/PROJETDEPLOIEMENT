const express = require('express');
const cors = require('cors');
const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.get('/api/campaigns', (req, res) => {
  res.json([{ id: 1, name: "Campagne Test" }]);
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
const express = require('express');
const cors = require('cors');
const projectRoutes = require('./routes/projectRoutes');
const forumRoutes = require('./routes/forumRoutes');
const authRoutes = require('./routes/authRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const userRoutes = require('./routes/userRoutes');
const roadmapRoutes = require('./routes/roadmapRoutes');

const app = express();
app.use(cors());
app.use(express.json());

app.use('/api/projects', projectRoutes);
app.use('/api/forum', forumRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/users', userRoutes);
app.use('/api/roadmap', roadmapRoutes);

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
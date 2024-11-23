#!/bin/bash

# Exit if any command fails
set -e

# Step 1: Create project directory and navigate into it
mkdir -p TraineeTimeTracker && cd TraineeTimeTracker

# Step 2: Initialize a new Node.js project
npm init -y

# Step 3: Install necessary dependencies
npm install express mongoose jsonwebtoken bcrypt nodemailer node-cron next react react-dom @types/react @types/react-dom typescript @types/node

# Step 4: Create directory structure
mkdir -p src/{pages,components/ui,server/{routes,models,services,controllers}}

# Step 5: Generate main server file
cat << 'EOF' > src/server/index.ts
import express from 'express';
import mongoose from 'mongoose';
import cron from 'node-cron';

const app = express();

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Connect to MongoDB
mongoose.connect('mongodb://localhost/trainee_time_tracker', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// Define routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/trainees', require('./routes/trainees'));
app.use('/api/admin', require('./routes/admin'));

// Google Sheets sync (every 5 minutes)
cron.schedule('*/5 * * * *', () => {
  console.log('Google Sheets sync triggered!');
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(\`Server running on port \${PORT}\`);
});
EOF

# Step 6: Generate Next.js main page
cat << 'EOF' > src/pages/index.tsx
import React from 'react';

export default function Home() {
  return (
    <div>
      <h1>Welcome to Trainee Time Tracker</h1>
    </div>
  );
}
EOF

# Step 7: Create additional service and controller files (examples)
cat << 'EOF' > src/server/services/auth.ts
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';
import { User } from '../models/User';

export const generateToken = (user: any) => {
  return jwt.sign({ id: user.id, role: user.role }, process.env.JWT_SECRET, {
    expiresIn: '1d',
  });
};
EOF

cat << 'EOF' > src/server/controllers/dataProtection.ts
import { Trainee } from '../models/Trainee';
import { TimeEntry } from '../models/TimeEntry';

export const getTraineeData = async (traineeId: string) => {
  const trainee = await Trainee.findById(traineeId);
  const timeEntries = await TimeEntry.find({ traineeId });

  return {
    personalInfo: trainee,
    timeEntries: timeEntries,
  };
};
EOF

# Step 8: Generate a README file
cat << 'EOF' > README.md
# Trainee Time Tracker

A secure and centralized time-tracking app for trainees.

## Setup Instructions
1. Install Node.js and MongoDB.
2. Clone the repository.
3. Run \`npm install\` to install dependencies.
4. Start the development server:
   \`\`\`
   npm run dev
   \`\`\`
5. Open the application at [http://localhost:3000](http://localhost:3000).

## Features
- Integration with Google Sheets
- Role-based access control
- Admin panel for trainers
EOF

# Display completion message
echo "Setup script executed successfully! Project structure and files have been generated."
echo "To start the project:"
echo "1. Navigate to the TraineeTimeTracker directory."
echo "2. Run 'npm run dev' to start the development server."

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { ScrollArea } from '@/components/ui/scroll-area'

export default function Component() {
  const [showInstructions, setShowInstructions] = useState(false)

  const bashScript = `
#!/bin/bash

# Create project directory and navigate into it
mkdir TraineeTimeTracker && cd TraineeTimeTracker

# Initialize a new Node.js project
npm init -y

# Install necessary dependencies
npm install express mongoose jsonwebtoken bcrypt nodemailer node-cron next react react-dom @types/react @types/react-dom typescript @types/node

# Create directory structure
mkdir -p src/{pages,components/ui,server/{routes,models,services,controllers}}

# Create main server file
cat << EOF > src/server/index.ts
import express from 'express';
import mongoose from 'mongoose';
import { google } from 'googleapis';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';
import nodemailer from 'nodemailer';
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
  // Implement Google Sheets sync logic
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(\`Server running on port \${PORT}\`);
});
EOF

# Create main page file
cat << EOF > src/pages/index.tsx
import { useState, useEffect } from 'react';
import { useRouter } from 'next/router';
import { Button, Select, Input } from '@/components/ui';

export default function Home() {
  const [departments, setDepartments] = useState([]);
  const [selectedDepartment, setSelectedDepartment] = useState('');
  const [trainees, setTrainees] = useState([]);
  const [selectedTrainee, setSelectedTrainee] = useState('');
  const router = useRouter();

  useEffect(() => {
    // Fetch departments and trainees
  }, []);

  const handleClockIn = async () => {
    // Implement clock-in logic
  };

  return (
    <div className="container mx-auto p-4">
      <h1 className="text-2xl font-bold mb-4">Trainee Time Tracker</h1>
      <Select
        options={departments}
        value={selectedDepartment}
        onChange={setSelectedDepartment}
        placeholder="Select Department"
      />
      <Select
        options={trainees}
        value={selectedTrainee}
        onChange={setSelectedTrainee}
        placeholder="Select Trainee"
        disabled={!selectedDepartment}
      />
      <Button onClick={handleClockIn} disabled={!selectedTrainee}>
        Clock In
      </Button>
    </div>
  );
}
EOF

# Create admin dashboard file
cat << EOF > src/pages/admin/dashboard.tsx
import { useState, useEffect } from 'react';
import { Table, Button } from '@/components/ui';

export default function AdminDashboard() {
  const [weeklySummary, setWeeklySummary] = useState([]);

  useEffect(() => {
    // Fetch weekly summary data
  }, []);

  const handleManualSync = async () => {
    // Implement manual sync with Google Sheets
  };

  return (
    <div className="container mx-auto p-4">
      <h1 className="text-2xl font-bold mb-4">Admin Dashboard</h1>
      <Button onClick={handleManualSync}>Manual Sync</Button>
      <Table
        columns={[
          { header: 'Trainee', accessor: 'name' },
          { header: 'Department', accessor: 'department' },
          { header: 'Present Days', accessor: 'presentDays' },
          { header: 'Late Count', accessor: 'lateCount' },
        ]}
        data={weeklySummary}
      />
    </div>
  );
}
EOF

# Create authentication service file
cat << EOF > src/server/services/auth.ts
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';
import { User } from '../models/User';

export const generateToken = (user: any) => {
  return jwt.sign({ id: user.id, role: user.role }, process.env.JWT_SECRET, {
    expiresIn: '1d',
  });
};

export const verifyToken = (token: string) => {
  return jwt.verify(token, process.env.JWT_SECRET);
};

export const hashPassword = async (password: string) => {
  return await bcrypt.hash(password, 10);
};

export const comparePassword = async (password: string, hashedPassword: string) => {
  return await bcrypt.compare(password, hashedPassword);
};

export const authenticateUser = async (email: string, password: string) => {
  const user = await User.findOne({ email });
  if (!user) {
    throw new Error('User not found');
  }

  const isPasswordValid = await comparePassword(password, user.password);
  if (!isPasswordValid) {
    throw new Error('Invalid password');
  }

  return generateToken(user);
};
EOF

# Create Google Sheets integration file
cat << EOF > src/server/services/googleSheets.ts
import { google } from 'googleapis';

const auth = new google.auth.GoogleAuth({
  keyFile: 'path/to/your/credentials.json',
  scopes: ['https://www.googleapis.com/auth/spreadsheets'],
});

const sheets = google.sheets({ version: 'v4', auth });

export const syncWithGoogleSheets = async (data: any) => {
  try {
    const response = await sheets.spreadsheets.values.update({
      spreadsheetId: 'YOUR_SPREADSHEET_ID',
      range: 'Sheet1!A1',
      valueInputOption: 'RAW',
      requestBody: {
        values: data,
      },
    });

    console.log('Google Sheets sync completed');
    return response.data;
  } catch (error) {
    console.error('Error syncing with Google Sheets:', error);
    throw error;
  }
};
EOF

# Create email notification service file
cat << EOF > src/server/services/email.ts
import nodemailer from 'nodemailer';

const transporter = nodemailer.createTransport({
  host: 'smtp.example.com',
  port: 587,
  secure: false,
  auth: {
    user: 'your-email@example.com',
    pass: 'your-password',
  },
});

export const sendLateNotification = async (traineeEmail: string, trainerEmail: string) => {
  try {
    await transporter.sendMail({
      from: '"Time Tracker" <timetracker@example.com>',
      to: \`\${traineeEmail}, \${trainerEmail}\`,
      subject: 'Late Arrival Notification',
      text: 'You have been marked as late for today.',
      html: '<b>You have been marked as late for today.</b>',
    });
    console.log('Late notification email sent');
  } catch (error) {
    console.error('Error sending late notification email:', error);
  }
};
EOF

# Create data protection controller file
cat << EOF > src/server/controllers/dataProtection.ts
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

export const deleteTraineeData = async (traineeId: string) => {
  await Trainee.findByIdAndDelete(traineeId);
  await TimeEntry.deleteMany({ traineeId });

  return { message: 'Trainee data deleted successfully' };
};

export const logDataProcessingOperation = async (operation: string, details: any) => {
  // Implement logging logic here
};
EOF

# Create a basic README file
cat << EOF > README.md
# Trainee Time Tracker

This is a secure, centralized Trainee time tracking app for an Organization that houses 50 trainees across 6 Cohorts/departments.

## Setup

1. Clone the repository
2. Run \`npm install\` to install dependencies
3. Set up your MongoDB database
4. Configure your Google Sheets API credentials
5. Set up your email service credentials
6. Run \`npm run dev\` to start the development server

## Features

- Integration with Google Sheets
- Secure clock-in system
- Admin panel for trainers
- Role-based access control
- Compliance with data protection regulations

For more details, please refer to the documentation.
EOF

echo "Project structure and initial files have been created."

# Instructions to run and view the project
echo "To run the project:"
echo "1. Start your MongoDB server"
echo "2. Run 'npm run dev' to start the development server"
echo "3. Open a web browser and navigate to http://localhost:3000"
`

  return (
    <div className="p-4 max-w-4xl mx-auto">
      <h1 className="text-2xl font-bold mb-4">Trainee Time Tracker Setup Instructions</h1>
      <Button 
        onClick={() => setShowInstructions(!showInstructions)}
        className="mb-4"
      >
        {showInstructions ? 'Hide' : 'Show'} Setup Instructions
      </Button>
      {showInstructions && (
        <ScrollArea className="h-[500px] border rounded p-4">
          <pre className="whitespace-pre-wrap">{bashScript}</pre>
        </ScrollArea>
      )}
    </div>
  )
}

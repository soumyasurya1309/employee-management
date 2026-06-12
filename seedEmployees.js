const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore, Timestamp } = require('firebase-admin/firestore');
const serviceAccount = require('./serviceAccountKey.json');

initializeApp({
  credential: cert(serviceAccount)
});

const db = getFirestore();

const firstNames = ['Aarav','Vivaan','Aditya','Vihaan','Arjun','Sai','Reyansh','Krishna','Ishaan','Rohan',
  'Ananya','Diya','Saanvi','Aadhya','Kiara','Myra','Aanya','Pari','Riya','Anika',
  'Rahul','Karan','Amit','Vikram','Sanjay','Deepak','Manish','Rajesh','Suresh','Arun',
  'Pooja','Neha','Sneha','Kavya','Priya','Shreya','Meera','Anjali','Divya','Nisha'];

const lastNames = ['Sharma','Verma','Gupta','Patel','Kumar','Singh','Reddy','Nair','Iyer','Joshi',
  'Mehta','Rao','Kapoor','Malhotra','Chopra','Bansal','Agarwal','Pillai','Desai','Shah'];

const departments = ['Engineering','HR','Finance','Marketing','Sales','Operations','IT','Design','Legal','Support'];

const designations = {
  Engineering: ['Software Engineer','Senior Engineer','Tech Lead','QA Engineer','DevOps Engineer'],
  HR: ['HR Executive','HR Manager','Recruiter','HR Generalist'],
  Finance: ['Accountant','Financial Analyst','Finance Manager'],
  Marketing: ['Marketing Executive','Digital Marketer','Marketing Manager','Content Strategist'],
  Sales: ['Sales Executive','Sales Manager','Account Manager','Business Dev Exec'],
  Operations: ['Operations Executive','Ops Manager','Process Analyst'],
  IT: ['System Admin','IT Support','Network Engineer'],
  Design: ['UI/UX Designer','Graphic Designer','Product Designer'],
  Legal: ['Legal Advisor','Compliance Officer'],
  Support: ['Support Executive','Customer Success','Support Lead']
};

function randomFrom(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

function randomDate(start, end) {
  return new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()));
}

async function seed() {
  const batchSize = 20;
  let batch = db.batch();
  let count = 0;

  for (let i = 1; i <= 100; i++) {
    const empId = `EMP${String(i).padStart(3, '0')}`;
    const firstName = randomFrom(firstNames);
    const lastName = randomFrom(lastNames);
    const department = randomFrom(departments);
    const designation = randomFrom(designations[department]);
    const joiningDate = randomDate(new Date(2018, 0, 1), new Date(2025, 11, 31));

    const employee = {
      employeeId: empId,
      name: `${firstName} ${lastName}`,
      email: `${firstName.toLowerCase()}.${lastName.toLowerCase()}${i}@company.com`,
      phone: `9${Math.floor(100000000 + Math.random() * 899999999)}`,
      department: department,
      designation: designation,
      salary: Math.floor(30000 + Math.random() * 70000),
      joiningDate: Timestamp.fromDate(joiningDate),
      address: `${Math.floor(1 + Math.random() * 999)}, Sample Street, City ${Math.floor(1 + Math.random() * 50)}`,
      createdAt: Timestamp.now()
    };

    const docRef = db.collection('employees').doc();
    batch.set(docRef, employee);
    count++;

    if (count % batchSize === 0) {
      await batch.commit();
      console.log(`Committed ${count} employees...`);
      batch = db.batch();
    }
  }

  if (count % batchSize !== 0) {
    await batch.commit();
  }

  console.log(`✅ Done! Seeded ${count} employees.`);
}

seed().catch(console.error);
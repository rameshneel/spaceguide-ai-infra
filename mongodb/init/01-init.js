// MongoDB initialization script
db = db.getSiblingDB("spaceguideai");

// Create application user
db.createUser({
  user: "appuser",
  pwd: "apppassword123",
  roles: [
    {
      role: "readWrite",
      db: "spaceguideai",
    },
  ],
});

// Create collections with indexes
db.createCollection("users");
db.users.createIndex({ email: 1 }, { unique: true });

db.createCollection("sessions");
db.sessions.createIndex({ userId: 1 });
db.sessions.createIndex({ createdAt: 1 }, { expireAfterSeconds: 86400 }); // 24 hours

db.createCollection("videos");
db.videos.createIndex({ userId: 1 });
db.videos.createIndex({ createdAt: -1 });

db.createCollection("images");
db.images.createIndex({ userId: 1 });
db.images.createIndex({ createdAt: -1 });

db.createCollection("chats");
db.chats.createIndex({ userId: 1 });
db.chats.createIndex({ createdAt: -1 });

print("Database initialization completed successfully");

const bcrypt = require('bcrypt');
bcrypt.hash('Admin@1234', 12).then(console.log);

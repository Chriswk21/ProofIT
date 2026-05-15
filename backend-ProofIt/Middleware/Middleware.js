const jwt = require('jsonwebtoken');

const verifyToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
        return res.status(401).json({ message: "Akses ditolak. Token tidak ditemukan." });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'rahasia_default_jangan_dipakai_di_production');
        req.user = decoded; // simpan data user ke req.user agar bisa dipakai di controller selanjutnya
        next();
    } catch (error) {
        return res.status(403).json({ message: "Token tidak valid atau sudah kadaluarsa." });
    }
};

module.exports = verifyToken;

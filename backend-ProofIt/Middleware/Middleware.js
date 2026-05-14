// // Middleware sederhana untuk mengecek apakah request memiliki header API Key
// // (Bisa dikembangkan menjadi pengecekan JWT Token nanti)
// const verifyToken = (req, res, next) => {
//     const apiKey = req.headers['x-api-key'];
//     if (!apiKey && process.env.NODE_ENV === 'production') {
//         return res.status(403).json({ message: "No API Key provided" });
//     }
//     next();
// };

// module.exports = verifyToken;
const supabase = require('../supabaseClient.js');
const jwt = require('jsonwebtoken');

const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('email', email)
      .eq('password_hash', password)
      .maybeSingle();

    if (error) {
      return res.status(400).json({
        status: 'error',
        message: error.message,
      });
    }

    if (!data) {
      return res.status(401).json({
        status: 'failed',
        message: 'Email atau password salah',
      });
    }

    // Buat JWT Token
    // Kita payload ID dan email agar di frontend/middleware bisa digunakan
    const token = jwt.sign(
      { userId: data.id, email: data.email, role: data.role },
      process.env.JWT_SECRET || 'rahasia_default_jangan_dipakai_di_production',
      { expiresIn: '7d' } // Token berlaku 7 hari
    );

    return res.status(200).json({
      status: 'success',
      user: data,
      token: token,
    });

  } catch (err) {
    return res.status(500).json({
      status: 'error',
      message: err.message,
    });
  }
};

module.exports = { login };
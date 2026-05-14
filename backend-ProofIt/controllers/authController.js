const supabase = require('../supabaseClient.js');

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

    return res.status(200).json({
      status: 'success',
      user: data,
    });

  } catch (err) {
    return res.status(500).json({
      status: 'error',
      message: err.message,
    });
  }
};

module.exports = { login };
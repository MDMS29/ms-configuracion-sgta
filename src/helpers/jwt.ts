import jwt from 'jsonwebtoken';

export const generar_token = (data: any) => jwt.sign(data, process.env.JWT_SECRET || 'secret', { expiresIn: '1h' });

export const validar_token = (token: string) => jwt.verify(token, process.env.JWT_SECRET || 'secret');
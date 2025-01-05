import { BCRYPT_SALT } from "@common/constants/constantes";
import bcrypt from "bcryptjs";

interface BcryptHash {
    hash: string;
    error: boolean;
}

export const hash_password = (password: string): BcryptHash => {
    try {
        const salt = bcrypt.genSaltSync(BCRYPT_SALT)
        const hash = bcrypt.hashSync(password, salt)

        return { hash, error: false }

    } catch (error) {
        console.log("🚀 ~ ERROR AL HASHEAR LA CONTRASEÑA DEL USUARIO ~ 🚀\n", error, "🚀 ~ FIN DE ERROR DE HASHEO ~ 🚀")
        return { hash: '', error: true }
    }
}

export const compare_password = (password: string, hash: string): boolean => {
    try {
        return bcrypt.compareSync(password, hash)
    } catch (error) {
        console.log("🚀 ~ ERROR AL COMPARAR LA CONTRASEÑA DEL USUARIO ~ 🚀\n", error, "🚀 ~ FIN DE ERROR DE COMPARACION ~ 🚀")
        return false
    }
}
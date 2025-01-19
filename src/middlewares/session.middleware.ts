import { UsuariosService } from "@app/configuracion/usuarios/usuarios.service"
import { NextFunction, Response } from "express"
import { validar_token } from "src/helpers/jwt"
import { serverResponse } from "src/helpers/server-response"

interface IDecoded {
    id: number
}

export const sessionMiddleware = async (req: any, res: Response, next: NextFunction) => {
    try {
        const token = req.headers.authorization?.split(' ')[1]
        if (!token) return serverResponse(res, { statusCode: 401, message: 'No se ha iniciado sesión' })

        const { id } = validar_token(token) as IDecoded
        if (!id) return serverResponse(res, { statusCode: 401, message: 'No se ha iniciado sesión' })

        const usuarioService = new UsuariosService()
        const { data } = await usuarioService.buscar_usuario_id(`${id}`)
        if (!data) return serverResponse(res, { statusCode: 401, message: 'No se ha encontrado el usuario' })

        req.usuario = data

        next()
    } catch (error: any) {
        if (error.message.includes('jwt expired')) return serverResponse(res, { statusCode: 401, message: 'Inicie sesión para realizar esta acción' })

        console.log('----- MIDDLEWARE ERROR -----\n', error, '\n----- FIN MIDDLEWARE ERROR -----')
        
        return serverResponse(res, { statusCode: 500, message: 'Error al validar sesión' })
    }
}
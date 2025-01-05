import { BaseController } from "@common/bases/controller.base";
import { UsuariosService } from "./usuarios.service";
import { serverResponse } from "src/helpers/server-response";
import { REPONSES_CODES } from "@common/constants/constantes";
import { UsuarioSchema } from "./usuarios.dto";

export class UsuariosController extends BaseController<UsuariosService> {
    constructor() {
        super(UsuariosService);
    }

    async obtener_usuarios(req: any, res: any) {
        const { estado, empresa } = req.query

        if (!empresa) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: 'Debe seleccionar una empresa' })

        if (!estado) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: 'No se ha encontrado el estado para la operación' })

        const response = await this.service.obtener_usuarios(estado, empresa)

        return serverResponse(res, response)
    }

    async insertar_usuario(req: any, res: any) {
        const usuario = req.body

        const validate = UsuarioSchema.safeParse(usuario)
        if (!validate.success) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: validate.error.issues[0].message })

        const response = await this.service.insertar_actualizar_usuario(usuario)

        return serverResponse(res, response)
    }

    async buscar_usuario_id(req: any, res: any) {
        const { id } = req.params
        const { estado } = req.query

        const response = await this.service.buscar_usuario_id(id, estado)

        return serverResponse(res, response)
    }

    async actualizar_usuario(req: any, res: any) {
        const { id } = req.params
        const usuario = req.body

        if (!id || !Number(id)) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: 'No se ha encontrado el identificador de la operación', data: {} })

        usuario.id_usuario = Number(id)

        const validate = UsuarioSchema.safeParse(usuario)
        if (!validate.success) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: validate.error.issues[0].message })

        const response = await this.service.insertar_actualizar_usuario(usuario)

        return serverResponse(res, response)
    }

    async inactivar_activar_usuario(req: any, res: any) {
        const { id } = req.params
        const { estado } = req.query

        if (!estado) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: 'No se ha encontrado el estado para la usuario', data: {} })

        if (!id) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: 'No se ha encontrado el identificador del usuario', data: {} })

        const response = await this.service.inactivar_activar_usuario(id, estado)

        return serverResponse(res, response)
    }
}
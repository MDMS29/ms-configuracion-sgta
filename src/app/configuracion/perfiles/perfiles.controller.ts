import { BaseController } from "@common/bases/controller.base";
import { PerfilesService } from "./perfiles.service";
import { serverResponse } from "src/helpers/server-response";
import { REPONSES_CODES } from "@common/constants/constantes";
import { PerfilesSchema } from "./perfiles.dto";

export class PerfilesController extends BaseController<PerfilesService> {
    constructor() {
        super(PerfilesService);
    }

    async obtener_perfiles(req: any, res: any) {
        const { estado } = req.query

        if (!estado) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: 'No se ha encontrado el estado para la operación', data: [] })

        const response = await this.service.obtener_perfiles(estado)

        return serverResponse(res, response)
    }

    async insertar_accion(req: any, res: any) {
        const accion = req.body

        const validate = PerfilesSchema.safeParse(accion)
        if (!validate.success) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: validate.error.issues[0].message })

        const response = await this.service.insertar_actualizar_accion(accion)

        return serverResponse(res, response)
    }

    async buscar_accion_id(req: any, res: any) {
        const { id } = req.params

        const response = await this.service.buscar_accion_id(id)

        return serverResponse(res, response)
    }

    async actualizar_accion(req: any, res: any) {
        const { id } = req.params
        const accion = req.body

        if (!id || !Number(id)) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: 'No se ha encontrado el identificador de la operación', data: {} })

        accion.id_accion = Number(id)

        const validate = PerfilesSchema.safeParse(accion)
        if (!validate.success) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: validate.error.issues[0].message })

        const response = await this.service.insertar_actualizar_accion(accion)

        return serverResponse(res, response)
    }

    async inactivar_activar_accion(req: any, res: any) {
        const { id } = req.params
        const { estado } = req.query

        if (!estado) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: 'No se ha encontrado el estado para la accion', data: {} })

        if (!id) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: 'No se ha encontrado el identificador de la accion', data: {} })

        const response = await this.service.inactivar_activar_accion(id, estado)

        return serverResponse(res, response)
    }
}
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
        const { estado, empresa } = req.query

        if (!empresa) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: 'Debe seleccionar una empresa', data: [] })

        if (!estado) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: 'No se ha encontrado el estado para la operación', data: [] })

        const response = await this.service.obtener_perfiles(estado, empresa)

        return serverResponse(res, response)
    }

    async insertar_perfil(req: any, res: any) {
        const perfil = req.body

        const validate = PerfilesSchema.safeParse(perfil)
        if (!validate.success) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: validate.error.issues[0].message })

        const response = await this.service.insertar_actualizar_perfil(perfil)

        return serverResponse(res, response)
    }

    async buscar_perfil_id(req: any, res: any) {
        const { id } = req.params
        const { estado } = req.query

        const response = await this.service.buscar_perfil_id(id, estado)

        return serverResponse(res, response)
    }

    async actualizar_perfil(req: any, res: any) {
        const { id } = req.params
        const perfil = req.body

        if (!id || !Number(id)) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: 'No se ha encontrado el identificador de la operación', data: {} })

        perfil.id_perfil = Number(id)

        const validate = PerfilesSchema.safeParse(perfil)
        if (!validate.success) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: validate.error.issues[0].message })

        const response = await this.service.insertar_actualizar_perfil(perfil)

        return serverResponse(res, response)
    }

    async inactivar_activar_perfil(req: any, res: any) {
        const { id } = req.params
        const { estado } = req.query

        if (!estado) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: 'No se ha encontrado el estado para el perfil', data: {} })

        if (!id) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: 'No se ha encontrado el identificador de el perfil', data: {} })

        const response = await this.service.inactivar_activar_perfil(id, estado)

        return serverResponse(res, response)
    }
}
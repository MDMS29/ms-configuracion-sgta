import { BaseController } from "@common/bases/controller.base";
import { ModulosService } from "./modulos.service";
import { serverResponse } from "src/helpers/server-response";
import { DB_ESTADOS, REPONSES_CODES } from "@common/constants/constantes";

export class ModulosController extends BaseController<ModulosService> {
    constructor() {
        super(ModulosService);
    }

    async obtener_modulos(req: any, res: any) {
        const { estado } = req.query

        if (!estado) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: 'No se ha encontrado el estado para la operación', data: [] })

        const response = await this.service.obtener_modulos(estado)

        return serverResponse(res, response)
    }

    async insertar_modulo(req: any, res: any) {
        const modulo = req.body

        const response = await this.service.insertar_actualizar_modulo(modulo)

        return serverResponse(res, response)
    }

    async buscar_modulo_id(req: any, res: any) {
        const { id } = req.params as { id: string }
        const { estado } = req.query

        if (!id || !Number(id)) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: 'No se ha encontrado el identificador de la operación', data: {} })

        const params = JSON.stringify({ id, estado: estado ?? DB_ESTADOS.ACTIVO })

        const response = await this.service.buscar_modulo_id(params)

        return serverResponse(res, response)
    }

    async actualizar_modulo(req: any, res: any) {
        const { id } = req.params as { id: string }
        const modulo = req.body

        if (!id || !Number(id)) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: 'No se ha encontrado el identificador de la operación', data: {} })

        modulo.id_modulo = id

        const response = await this.service.insertar_actualizar_modulo(modulo)

        return serverResponse(res, response)
    }

    async inactivar_activar_modulo(req: any, res: any) {
        const { id } = req.params
        const { estado } = req.query

        if (!estado) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: 'No se ha encontrado el estado para el modulo', data: {} })

        if (!id) return serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: 'No se ha encontrado el identificador del modulo', data: {} })

        const response = await this.service.inactivar_activar_modulo(id, estado)

        return serverResponse(res, response)
    }
}
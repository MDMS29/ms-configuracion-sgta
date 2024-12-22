import { BaseController } from "@common/bases/controller.base";
import { ModulosService } from "./modulos.service";
import { serverResponse } from "src/helpers/server-response";
import { REPONSES_CODES } from "@common/constants/constantes";

export class ModulosController extends BaseController<ModulosService> {
    constructor() {
        super(ModulosService);
    }

    async obtener_modulos(req: any, res: any) {
        const { estado } = req.query

        if (!estado) serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: 'No se ha encontrado el estado para la operación', data: [] })

        const response = await this.service.obtener_modulos(estado)

        serverResponse(res, response)
    }

    async insertar_modulo(req: any, res: any) {
        const modulo = req.body

        const response = await this.service.insertar_actualizar_modulo(modulo)

        serverResponse(res, response)
    }

    async buscar_modulo_id(req: any, res: any) {
        const { id } = req.params

        const response = await this.service.buscar_modulo_id(id)

        serverResponse(res, response)
    }

    async actualizar_modulo(req: any, res: any) {
        const { id } = req.params
        const modulo = req.body

        if (!id) serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: 'No se ha encontrado el identificador de la operación', data: {} })

        modulo.id_modulo = id

        const response = await this.service.insertar_actualizar_modulo(modulo)

        serverResponse(res, response)
    }

    async inactivar_activar_modulo(req: any, res: any) {
        const { id } = req.params
        const { estado } = req.query

        if (!estado) serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: 'No se ha encontrado el estado para la modulo', data: {} })

        if (!id) serverResponse(res, { statusCode: REPONSES_CODES.BAD_REQUEST, message: 'No se ha encontrado el identificador de la modulo', data: {} })

        const response = await this.service.inactivar_activar_modulo(id, estado)

        serverResponse(res, response)
    }
}
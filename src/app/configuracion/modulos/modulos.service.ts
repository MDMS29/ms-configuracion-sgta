import { BaseService } from "@common/bases/services.base";
import { ModulosQuerys } from "./modulos.querys";
import { DB_ESTADOS, REPONSES_CODES } from "@common/constants/constantes";
import { ModuloDto } from "./modulo.dto";

export class ModulosService extends BaseService<ModulosQuerys> {
    constructor() {
        super(ModulosQuerys);
    }

    async obtener_modulos(estado: string, menus?: boolean) {
        let modulos: any

        if (menus) {
            modulos = await this.query.obtener_modulos_menus_acciones()
        } else {
            modulos = await this.query.obtener_modulos(estado)
        }

        return modulos
    }

    async insertar_actualizar_modulo(modulo: ModuloDto) {
        modulo.usuario_accion = 1

        const tiene_menus_activos = modulo.menus?.some(menu => menu.id_estado === DB_ESTADOS.ACTIVO)
        if (!modulo.es_menu && !tiene_menus_activos) return { statusCode: REPONSES_CODES.BAD_REQUEST, message: 'El módulo debte tener al menos un menú activo' }

        // PARSEAR DATA A STRING PARA PROCEDURE
        const moduloBody = JSON.stringify(modulo)

        const response = await this.query.insertar_actualizar_modulo(moduloBody)

        return response
    }

    async buscar_modulo_id(params: string) {
        const modulo = await this.query.buscar_modulo_id(params)

        if (!modulo) {
            return { statusCode: REPONSES_CODES.NOT_FOUND, message: 'No se ha encontro el registro', data: {} }
        }

        return modulo
    }

    async inactivar_activar_modulo(id: string, estado: string) {
        const data = { id, estado, usuario_accion: 1 }
        const parametros = JSON.stringify(data)

        const response = await this.query.inactivar_activar_modulo(parametros)

        return response
    }

}
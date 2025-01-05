import { BaseService } from "@common/bases/services.base";
import { UsuariosQuerys } from "./usuarios.querys";
import { DB_ESTADOS, REPONSES_CODES } from "@common/constants/constantes";
import { hash_password } from "src/helpers/bcrypt.hash";
import { UsuarioDto } from "./usuarios.dto";
import { isEmpty } from "src/helpers/isEmpty";

export class UsuariosService extends BaseService<UsuariosQuerys> {
    constructor() {
        super(UsuariosQuerys);
    }

    async obtener_usuarios(estado: string, empresa: string) {
        const params = JSON.stringify({ estado, empresa })

        const response = await this.query.obtener_usuarios(params)
        return response
    }

    async insertar_actualizar_usuario(usuario: UsuarioDto) {
        usuario.usuario_accion = 1

        // VALIDAR SI SE DEBE HASHEAR LA CLAVE
        if (!isEmpty(usuario.clave)) {
            const { hash, error } = hash_password(usuario.clave)
            if (error) return { statusCode: REPONSES_CODES.INTERNAL_SERVER_ERROR, message: 'Error al guardar el usuario', data: {} }
            usuario.clave = hash
        }else{
            const params = JSON.stringify({ id: usuario.id_usuario, estado: DB_ESTADOS.ACTIVO, ver_clave: true })
            const usuarioExistente = await this.query.buscar_usuario_id(params)

            usuario.clave = usuarioExistente.data.clave
        }

        // PARSEAR DATA A STRING PARA PROCEDURE
        const newUsuario = JSON.stringify(usuario)
        const response = await this.query.insertar_actualizar_usuario(newUsuario)

        return response
    }

    async buscar_usuario_id(id: string, estado: string) {
        const params = JSON.stringify({ id, estado: estado ?? DB_ESTADOS.ACTIVO })

        const response = await this.query.buscar_usuario_id(params)

        return response
    }

    async inactivar_activar_usuario(id: string, estado: string) {
        const data = { id, estado, usuario_accion: 1 }
        const parametros = JSON.stringify(data)

        const response = await this.query.inactivar_activar_usuario(parametros)

        return response
    }

}
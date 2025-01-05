import { BaseService } from "@common/bases/services.base";
import { AuthQuerys } from "./auth.querys";
import { DB_ESTADOS, REPONSES_CODES } from "@common/constants/constantes";
import { InicioSesionDto } from "./auth.dto";
import { UsuariosQuerys } from "@app/configuracion/usuarios/usuarios.querys";
import { compare_password } from "src/helpers/bcrypt.hash";
import { generar_token } from "src/helpers/jwt";

export class AuthService extends BaseService<AuthQuerys> {
    private UsuariosQuerys: UsuariosQuerys

    constructor() {
        super(AuthQuerys);

        this.UsuariosQuerys = new UsuariosQuerys()
    }

    async inicio_sesion(body: InicioSesionDto) {
        const params = JSON.stringify({ usuario: body.usuario, estado: DB_ESTADOS.ACTIVO, ver_clave: true })

        const { data } = await this.UsuariosQuerys.buscar_usuario_id(params)
        if (!data) return { statusCode: REPONSES_CODES.UNAUTHORIZED, message: 'No se ha encontrado el usuario' }

        const es_usuario = compare_password(body.clave, data.clave)
        if (!es_usuario) return { statusCode: REPONSES_CODES.UNAUTHORIZED, message: 'Usuario o clave incorrectos' }

        const response = await this.query.inicio_sesion(data.id_usuario)

        response.data.token = generar_token(data.id_usuario)

        return response
    }

}
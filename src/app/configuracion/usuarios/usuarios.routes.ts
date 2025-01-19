import { BaseRouter } from "@common/bases/router.base";
import { UsuariosController } from "./usuarios.controller";
import { sessionMiddleware } from "src/middlewares/session.middleware";

export class UsuariosRouter extends BaseRouter<UsuariosController> {

    constructor() {
        super(UsuariosController, "configuracion/usuarios");
    }

    routes(): void {
        this.router.route(`/${this.subcarpeta}`)
            .get(sessionMiddleware, (req, res) => this.controller.obtener_usuarios(req, res))
            .post(sessionMiddleware, (req, res) => this.controller.insertar_usuario(req, res))

        this.router.route(`/${this.subcarpeta}/:id`)
            .get(sessionMiddleware, (req, res) => this.controller.buscar_usuario_id(req, res))
            .put(sessionMiddleware, (req, res) => this.controller.actualizar_usuario(req, res))
            .delete(sessionMiddleware, (req, res) => this.controller.inactivar_activar_usuario(req, res))
    }

}

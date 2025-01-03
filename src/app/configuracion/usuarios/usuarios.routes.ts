import { BaseRouter } from "@common/bases/router.base";
import { UsuariosController } from "./usuarios.controller";

export class UsuariosRouter extends BaseRouter<UsuariosController> {

    constructor() {
        super(UsuariosController, "configuracion/usuarios");
    }

    routes(): void {
        this.router.route(`/${this.subcarpeta}`)
            .get((req, res) => this.controller.obtener_usuarios(req, res))
            .post((req, res) => this.controller.insertar_accion(req, res))

        this.router.route(`/${this.subcarpeta}/:id`)
            .get((req, res) => this.controller.buscar_accion_id(req, res))
            .put((req, res) => this.controller.actualizar_accion(req, res))
            .delete((req, res) => this.controller.inactivar_activar_accion(req, res))
    }

}

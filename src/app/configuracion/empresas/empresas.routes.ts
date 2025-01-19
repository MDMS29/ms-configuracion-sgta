import { BaseRouter } from "@common/bases/router.base";
import { EmpresasController } from "./empresas.controller";
import { sessionMiddleware } from "src/middlewares/session.middleware";

export class EmpresasRouter extends BaseRouter<EmpresasController> {

    constructor() {
        super(EmpresasController, "configuracion/empresas");
    }

    routes(): void {
        this.router.route(`/${this.subcarpeta}`)
            .get(sessionMiddleware, (req, res) => this.controller.obtener_empresas(req, res))
            .post(sessionMiddleware, (req, res) => this.controller.insertar_empresa(req, res))

        this.router.route(`/${this.subcarpeta}/:id`)
            .get(sessionMiddleware, (req, res) => this.controller.buscar_empresa_id(req, res))
            .put(sessionMiddleware, (req, res) => this.controller.actualizar_empresa(req, res))
            .delete(sessionMiddleware, (req, res) => this.controller.inactivar_activar_empresa(req, res))
    }

}

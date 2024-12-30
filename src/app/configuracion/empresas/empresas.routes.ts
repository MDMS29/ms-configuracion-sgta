import { BaseRouter } from "@common/bases/router.base";
import { EmpresasController } from "./empresas.controller";

export class EmpresasRouter extends BaseRouter<EmpresasController> {

    constructor() {
        super(EmpresasController, "configuracion/empresas");
    }

    routes(): void {
        this.router.route(`/${this.subcarpeta}`)
            .get((req, res) => this.controller.obtener_empresas(req, res))
            .post((req, res) => this.controller.insertar_empresa(req, res))

        this.router.route(`/${this.subcarpeta}/:id`)
            .get((req, res) => this.controller.buscar_empresa_id(req, res))
            .put((req, res) => this.controller.actualizar_empresa(req, res))
            .delete((req, res) => this.controller.inactivar_activar_empresa(req, res))
    }

}

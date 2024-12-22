import { BaseRouter } from "@common/bases/router.base";
import { ModulosController } from "./modulos.controller";

export class ModulosRouter extends BaseRouter<ModulosController> {

    constructor() {
        super(ModulosController, "configuracion/modulos");
    }

    routes(): void {
        this.router.route(`/${this.subcarpeta}`)
            .get((req, res) => this.controller.obtener_modulos(req, res))
            .post((req, res) => this.controller.insertar_modulo(req, res))

        this.router.route(`/${this.subcarpeta}/:id`)
            .get((req, res) => this.controller.buscar_modulo_id(req, res))
            .put((req, res) => this.controller.actualizar_modulo(req, res))
            .delete((req, res) => this.controller.inactivar_activar_modulo(req, res))
    }

}

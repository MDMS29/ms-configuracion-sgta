import { AccionesRouter } from "./configuracion/acciones/acciones.routes";
import { EmpresasRouter } from "./configuracion/empresas/empresas.routes";
import { ModulosRouter } from "./configuracion/modulos/modulos.routes";

export const ROUTES = [
    new AccionesRouter().router,
    new ModulosRouter().router,
    new EmpresasRouter().router
]

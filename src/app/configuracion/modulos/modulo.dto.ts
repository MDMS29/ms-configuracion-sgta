import { IRequest } from "@common/interfaces/server.interface";
import z from "zod";
import { AccionDto } from "../acciones/acciones.dto";

export interface ModuloDto extends IRequest {
    id_modulo: number;
    descripcion: string;
    es_menu: boolean;
    link: string;
    menus?: MenuDto[];
    acciones?: RelacionModuloMenuAccionDto[];
}

export interface MenuDto {
    id_menu: number;
    descripcion: string;
    link: string;
    id_estado: number;
    acciones?: RelacionModuloMenuAccionDto[];
}

interface RelacionModuloMenuAccionDto extends AccionDto {
    id_menu?: number;
    id_modulo?: number;
    id_estado: number;
}

export const MenuSchema = z.object({
    id_menu: z.number({
        required_error: "Debe ingresar un identificador del menú",
        invalid_type_error: "El identificador del menú debe ser un número",
    }).optional(),
    descripcion: z.string({
        required_error: "Debe ingresar una descripción valida para el menú",
        invalid_type_error: "La descripción debe ser texto",
    }),
    link: z.string({
        required_error: "Debe ingresar un enlace valido para el menú",
        invalid_type_error: "El enlace del menú debe ser un texto",
    }),
    id_estado: z.number({
        required_error: "Debe ingresar un estado",
        invalid_type_error: "El estado del menú debe ser un número",
    }).optional(),
})

export const ModuloSchema = z.object({
    id_modulo: z.number({
        required_error: "Debe ingresar un identificador del módulo",
        invalid_type_error: "El identificador del módulo debe ser un número",
    }).optional(),
    descripcion: z.string({
        required_error: "Debe ingresar una descripción para el módulo",
        invalid_type_error: "La descripción debe ser texto",
    }),
    es_menu: z.boolean({
        required_error: "Seleccione si el módulo es un menú",
        invalid_type_error: "El valor debe ser un booleano",
    }),
    link: z.string({
        required_error: "Debe ingresar un enlace valido para el módulo",
        invalid_type_error: "El enlace del módulo debe ser un texto",
    }).optional(),
    id_estado: z.number({
        required_error: "Debe ingresar un estado",
        invalid_type_error: "El estado del módulo debe ser un número",
    }).optional(),
    menus: z.array(MenuSchema).optional(),
})

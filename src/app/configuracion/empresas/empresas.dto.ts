import z from "zod";
import { ModuloDto, ModuloSchema } from "../modulos/modulo.dto";

export interface EmpresaDto {
    id_empresa: number;
    nit: string;
    razon_social: string;
    correo: string;
    telefono: string;
    direccion: string;
    modulos: Partial<ModuloDto>[];
}

export const EmpresaSchema = z.object({
    id_empresa: z.number({
        required_error: "Debe ingresar un identificador de la empresa",
        invalid_type_error: "El identificador de la empresa debe ser un número",
    }).optional(),
    id_pais: z.number({
        required_error: "Debe seleccionar un país",
        invalid_type_error: "El identificador del pais debe ser un número",
    }).optional(),
    nit: z.string({
        required_error: "Debe ingresar un NIT valida",
        invalid_type_error: "El NIT debe ser un texto",
    }),
    razon_social: z.string({
        required_error: "Debe ingresar una razón social valida",
        invalid_type_error: "La razón social debe ser un texto",
    }),
    correo: z.string({
        required_error: "Debe ingresar un correo valido",
        invalid_type_error: "El correo debe ser un texto",
    }).email({
        message: "Debe ingresar un correo valido",
    }),
    telefono: z.string({
        required_error: "Debe ingresar un telefono valido",
        invalid_type_error: "El telefono debe ser un texto",
    }),
    direccion: z.string({
        required_error: "Debe ingresar una dirección valida",
        invalid_type_error: "La dirección debe ser un texto",
    }),
    modulos: z.array(ModuloSchema.partial(), { required_error: "Debe ingresar al menos un módulo", invalid_type_error: "Los módulos deben ser un array" }),
})
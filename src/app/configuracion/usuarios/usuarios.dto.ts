import z from "zod";
import { AccionesPerfil, PerfilesDto } from "../perfiles/perfiles.dto";

export interface UsuarioDto {
    id_usuario: number;
    nombres: string;
    apellidos: string;
    usuario: string;
    correo: string;
    clave: string;
    id_estado: number;
    id_empresa: number;
    perfiles: Partial<PerfilesDto>[]
    acciones: Partial<AccionesPerfil>[]
    usuario_accion: number;
}

export const UsuarioSchema = z.object({
    id_usuario: z.number({
        required_error: "Debe ingresar un identificador del usuario",
        invalid_type_error: "El identificador del usuario debe ser un número",
    }).optional(),
    id_empresa: z.number({
        required_error: "Debe ingresar la empresa del usuario",
        invalid_type_error: "La empresa del usuario debe ser un número",
    }),
    nombres: z.string({
        required_error: "Debe ingresar un nombre valido",
        invalid_type_error: "El nombre debe ser texto",
    }),
    apellidos: z.string({
        required_error: "Debe ingresar un apellido valido",
        invalid_type_error: "El apellido debe ser texto",
    }),
    usuario: z.string({
        required_error: "Debe ingresar un usuario valido",
        invalid_type_error: "El usuario debe ser texto",
    }),
    correo: z.string({
        required_error: "Debe ingresar un correo valido",
        invalid_type_error: "El correo debe ser texto",
    }),
    clave: z.string({
        required_error: "Debe ingresar una clave valido",
        invalid_type_error: "La clave debe ser texto",
    }).optional(),
    id_estado: z.number({
        required_error: "Debe ingresar el estado del usuario",
        invalid_type_error: "El estado debe ser un número",
    }).optional(),
    perfiles: z.array(
        z.object({
            id_perfil: z.number({
                required_error: "Debe ingresar un identificador de perfil",
                invalid_type_error: "El identificador de perfil debe ser un número",
            }),
            id_estado: z.number({
                required_error: "Debe ingresar el estado de la acción",
                invalid_type_error: "El estado debe ser un número",
            }),
        })
    ),
    acciones: z.array(
        z.object({
            id_accion_perfil: z.number({
                required_error: "Debe ingresar un identificador de la acción",
                invalid_type_error: "El identificador de la acción debe ser un número",
            }),
            id_estado: z.number({
                required_error: "Debe ingresar el estado de la acción",
                invalid_type_error: "El estado debe ser un número",
            }),
        })
    ),
})
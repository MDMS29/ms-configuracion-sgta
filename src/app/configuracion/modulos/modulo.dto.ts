import { IRequest } from "@common/interfaces/server.interface";

export interface ModuloDto extends IRequest {
    id_modulo: number;
    descripcion: string;
    es_menu: boolean;
    link: string;
    menus?: MenuDto[];
}

export interface MenuDto {
    id_menu: number;
    descripcion: string;
    link: string;
    id_estado: number;
}
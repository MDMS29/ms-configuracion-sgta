
CREATE SCHEMA "seguridad";

--GENERANDO TABLAS
CREATE TABLE seguridad."tbl_estados" (
	"id_estado" SERIAL NOT NULL ,
	"descripcion" VARCHAR(50) NOT NULL ,
	PRIMARY KEY("id_estado")
);
CREATE TABLE seguridad."tbl_acciones" (
	"id_accion" SERIAL NOT NULL ,
	"descripcion" VARCHAR(50) NOT NULL ,
	"id_estado" INTEGER NOT NULL ,
	"usuario_crea" INTEGER NOT NULL ,
	"fecha_crea" TIMESTAMP NOT NULL ,
	"usuario_actua" INTEGER NULL ,
	"fecha_actua" TIMESTAMP NULL ,
	PRIMARY KEY("id_accion")
);
CREATE TABLE seguridad."tbl_modulos" (
	"id_modulo" SERIAL NOT NULL ,
	"descripcion" VARCHAR(100) NOT NULL ,
	"es_menu" BOOLEAN NOT NULL ,
	"link" TEXT NULL ,
	"id_estado" INTEGER NOT NULL ,
	"usuario_crea" INTEGER NOT NULL ,
	"fecha_crea" TIMESTAMP NOT NULL ,
	"usuario_actua" INTEGER NULL ,
	"fecha_actua" TIMESTAMP NULL ,
	PRIMARY KEY("id_modulo")
);
CREATE TABLE seguridad."tbl_menus" (
	"id_menu" SERIAL NOT NULL ,
	"descripcion" VARCHAR(100) NOT NULL ,
	"link" TEXT NOT NULL ,
	"id_estado" INTEGER NOT NULL ,
	"usuario_crea" INTEGER NOT NULL ,
	"fecha_crea" TIMESTAMP NOT NULL ,
	"usuario_actua" INTEGER NULL ,
	"fecha_actua" TIMESTAMP NULL ,
	"id_modulo" INT NOT NULL ,
	PRIMARY KEY("id_menu")
);
CREATE TABLE seguridad."tbl_acciones_menus" (
	"id_accion_menu" SERIAL NOT NULL ,
	"id_estado" INTEGER NOT NULL ,
	"usuario_crea" INTEGER NOT NULL ,
	"fecha_crea" TIMESTAMP NOT NULL ,
	"usuario_actua" INTEGER NULL ,
	"fecha_actua" TIMESTAMP NULL ,
	"id_menu" INT NOT NULL ,
	"id_modulo" INT NULL ,
	"id_accion" INT NULL ,
	PRIMARY KEY("id_accion_menu")
);
CREATE TABLE seguridad."tbl_empresas" (
	"id_empresa" SERIAL NOT NULL ,
	"nit" VARCHAR(20) NOT NULL ,
	"razon_social" VARCHAR(200) NOT NULL ,
	"correo" VARCHAR(250) NOT NULL ,
	"telefono" VARCHAR(12) NOT NULL ,
	"direccion" TEXT NOT NULL ,
	"id_estado" INTEGER NOT NULL ,
	"usuario_crea" INTEGER NOT NULL ,
	"fecha_crea" TIMESTAMP NOT NULL ,
	"usuario_actua" INTEGER NULL ,
	"fecha_actua" TIMESTAMP NULL ,
	"id_pais" INT NOT NULL ,
	PRIMARY KEY("id_empresa")
);
CREATE TABLE seguridad."tbl_modulos_empresas" (
	"id_modulo_empresa" SERIAL NOT NULL ,
	"id_estado" INTEGER NOT NULL ,
	"usuario_crea" INTEGER NOT NULL ,
	"fecha_crea" TIMESTAMP NOT NULL ,
	"usuario_actua" INTEGER NULL ,
	"fecha_actua" TIMESTAMP NULL ,
	"id_empresa" INT NOT NULL ,
	"id_modulo" INT NOT NULL ,
	PRIMARY KEY("id_modulo_empresa")
);
CREATE TABLE seguridad."tbl_perfiles" (
	"id_perfil" SERIAL NOT NULL ,
	"descripcion" VARCHAR(100) NOT NULL ,
	"id_estado" INTEGER NOT NULL ,
	"usuario_crea" INTEGER NOT NULL ,
	"fecha_crea" TIMESTAMP NOT NULL ,
	"usuario_actua" INTEGER NULL ,
	"fecha_actua" TIMESTAMP NULL ,
	"id_empresa" INT NOT NULL ,
	PRIMARY KEY("id_perfil")
);
CREATE TABLE seguridad."tbl_acciones_perfiles" (
	"id_accion_perfil" SERIAL NOT NULL ,
	"id_estado" INTEGER NOT NULL ,
	"usuario_crea" INTEGER NOT NULL ,
	"fecha_crea" TIMESTAMP NOT NULL ,
	"usuario_actua" INTEGER NULL ,
	"fecha_actua" TIMESTAMP NULL ,
	"id_accion_menu" INT NOT NULL ,
	"id_perfil" INT NOT NULL ,
	PRIMARY KEY("id_accion_perfil")
);
CREATE TABLE seguridad."tbl_usuarios" (
	"id_usuario" SERIAL NOT NULL ,
	"nombres" VARCHAR(100) NOT NULL ,
	"apellidos" VARCHAR(100) NOT NULL ,
	"usuario" VARCHAR(12) NOT NULL ,
	"correo" VARCHAR(200) NOT NULL ,
	"clave" TEXT NOT NULL ,
	"cm_clave" BOOLEAN NOT NULL ,
	"id_estado" INTEGER NOT NULL ,
	"usuario_crea" INTEGER NOT NULL ,
	"fecha_crea" TIMESTAMP NOT NULL ,
	"usuario_actua" INTEGER NULL ,
	"fecha_actua" TIMESTAMP NULL ,
	"id_empresa" INT NOT NULL ,
	PRIMARY KEY("id_usuario")
);
CREATE TABLE seguridad."tbl_acciones_usuarios" (
	"id_accion_usuario" SERIAL NOT NULL ,
	"id_estado" INTEGER NOT NULL ,
	"usuario_crea" INTEGER NOT NULL ,
	"fecha_crea" TIMESTAMP NOT NULL ,
	"usuario_actua" INTEGER NULL ,
	"fecha_actua" TIMESTAMP NULL ,
	"id_accion_perfil" INT NOT NULL ,
	"id_usuario" INT NOT NULL ,
	PRIMARY KEY("id_accion_usuario")
);
CREATE TABLE seguridad."tbl_perfiles_usuarios" (
	"id_perfil_usuario" SERIAL NOT NULL ,
	"id_estado" INTEGER NOT NULL ,
	"fecha_crea" TIMESTAMP NOT NULL ,
	"usuario_crea" INTEGER NOT NULL ,
	"fecha_actua" TIMESTAMP NULL ,
	"usuario_actua" INTEGER NULL ,
	"id_perfil" INT NOT NULL ,
	"id_usuario" INT NOT NULL ,
	PRIMARY KEY("id_perfil_usuario")
);

ALTER TABLE seguridad.tbl_acciones_menus ALTER COLUMN id_modulo DROP NOT NULL;
ALTER TABLE seguridad.tbl_acciones_menus ALTER COLUMN id_accion DROP NOT NULL;

--GENERANDO RELACIONES
ALTER TABLE seguridad."tbl_menus" ADD FOREIGN KEY ("id_modulo") REFERENCES seguridad."tbl_modulos" ("id_modulo");
ALTER TABLE seguridad."tbl_acciones_menus" ADD FOREIGN KEY ("id_menu") REFERENCES seguridad."tbl_menus" ("id_menu");
ALTER TABLE seguridad."tbl_acciones_menus" ADD FOREIGN KEY ("id_modulo") REFERENCES seguridad."tbl_modulos" ("id_modulo");
ALTER TABLE seguridad."tbl_acciones_menus" ADD FOREIGN KEY ("id_accion") REFERENCES seguridad."tbl_acciones" ("id_accion");
ALTER TABLE seguridad."tbl_modulos_empresas" ADD FOREIGN KEY ("id_empresa") REFERENCES seguridad."tbl_empresas" ("id_empresa");
ALTER TABLE seguridad."tbl_modulos_empresas" ADD FOREIGN KEY ("id_modulo") REFERENCES seguridad."tbl_modulos" ("id_modulo");
ALTER TABLE seguridad."tbl_perfiles" ADD FOREIGN KEY ("id_empresa") REFERENCES seguridad."tbl_empresas" ("id_empresa");
ALTER TABLE seguridad."tbl_acciones_perfiles" ADD FOREIGN KEY ("id_accion_menu") REFERENCES seguridad."tbl_acciones_menus" ("id_accion_menu");
ALTER TABLE seguridad."tbl_acciones_perfiles" ADD FOREIGN KEY ("id_perfil") REFERENCES seguridad."tbl_perfiles" ("id_perfil");
ALTER TABLE seguridad."tbl_usuarios" ADD FOREIGN KEY ("id_empresa") REFERENCES seguridad."tbl_empresas" ("id_empresa");
ALTER TABLE seguridad."tbl_acciones_usuarios" ADD FOREIGN KEY ("id_accion_perfil") REFERENCES seguridad."tbl_acciones_perfiles" ("id_accion_perfil");
ALTER TABLE seguridad."tbl_acciones_usuarios" ADD FOREIGN KEY ("id_usuario") REFERENCES seguridad."tbl_usuarios" ("id_usuario");
ALTER TABLE seguridad."tbl_perfiles_usuarios" ADD FOREIGN KEY ("id_perfil") REFERENCES seguridad."tbl_perfiles" ("id_perfil");
ALTER TABLE seguridad."tbl_perfiles_usuarios" ADD FOREIGN KEY ("id_usuario") REFERENCES seguridad."tbl_usuarios" ("id_usuario");



CREATE SCHEMA "parametros";
CREATE TABLE parametros."tbl_paises" (
	"id_pais" SERIAL NOT NULL ,
	"nombre" TEXT NOT NULL ,
	"resumen" VARCHAR(5) NOT NULL ,
	"prefijo_telefono" VARCHAR(10) NOT NULL ,
	PRIMARY KEY("id_pais")
);

ALTER TABLE seguridad."tbl_empresas" ADD FOREIGN KEY ("id_pais") REFERENCES parametros."tbl_paises" ("id_pais");
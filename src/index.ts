import { ROUTES } from '@app/app.routes';
import express from 'express';
import { logger } from './helpers/logger';
import cors from 'cors';
import { PostgresDB } from '@config/postgres.config';

class Server {

    private app: express.Application = express();
    private port: number = Number(process.env.PORT ?? 3000);
    private routes: express.Router[] = ROUTES;

    private postgres: PostgresDB = new PostgresDB();

    constructor() {
        this.app.disabled('x-powered-by');
        this.app.use(cors())
        this.app.use(express.urlencoded({ extended: true }));
        this.app.use(express.json());

        this.app.use("/api/v1", logger, this.routes);

        this.listen();
    }

    listen() {
        this.app.listen(this.port, () => {
            console.log(`\n ****     ****  ********        ********   ********  **********     **\n/**/**   **/** **//////        **//////   **//////**/////**///     ****\n/**//** ** /**/**             /**        **      //     /**       **//**\n/** //***  /**/********* *****/*********/**             /**      **  //**\n/**  //*   /**////////**///// ////////**/**    *****    /**     **********\n/**   /    /**       /**             /**//**  ////**    /**    /**//////**\n/**        /** ********        ********  //********     /**    /**     /**\n//         // ////////        ////////    ////////      //     //      //\n\n Server is running on port 3000`);

            this.postgres.test()
        });
    }
}

new Server();
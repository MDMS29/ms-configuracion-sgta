import { ROUTES } from '@app/app.routes';
import express from 'express';
import { logger } from './helpers/logger';
import cors from 'cors';

class Server {

    private app: express.Application = express();
    private port: number = Number(process.env.PORT ?? 3000);
    private routes: express.Router[] = ROUTES;

    constructor() {
        this.app.use((req, _, next) => logger(req, _, next));

        this.app.disabled('x-powered-by');
        this.app.use(cors())
        this.app.use(express.urlencoded({ extended: true }));
        this.app.use(express.json());

        this.app.use("/api/v1", this.routes);

        this.listen();
    }

    listen() {
        this.app.listen(this.port, () => {
            console.log(`\n ****     ****  ********        ********   ********  **********     **\n/**/**   **/** **//////        **//////   **//////**/////**///     ****\n/**//** ** /**/**             /**        **      //     /**       **//**\n/** //***  /**/********* *****/*********/**             /**      **  //**\n/**  //*   /**////////**///// ////////**/**    *****    /**     **********\n/**   /    /**       /**             /**//**  ////**    /**    /**//////**\n/**        /** ********        ********  //********     /**    /**     /**\n//         // ////////        ////////    ////////      //     //      //\n\n Server is running on port 3000`);
        });
    }
}

new Server();
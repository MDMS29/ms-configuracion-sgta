import { Pool } from 'pg';
import { POSTGRES_BD_CONFIG } from '@common/constants/server.constants';

export class PostgresDB {

    private _pool: Pool

    constructor() {
        this._pool = new Pool(POSTGRES_BD_CONFIG)
    }

    async test() {
        const client = await this._pool.connect()
        try {
            return client.query('SELECT NOW()')
        } catch (error) {
            console.log(error)
            return false
        } finally {
            client.release()
        }
    }

    async query(query: string, params?: any) {
        const client = await this._pool.connect()
        try {
            return client.query(query, params)
        } catch (error) {
            console.log(error)
            return client.release()
        } finally {
            client.release()
        }
    }

    async function(funcName: string, params?: any) {
        const client = await this._pool.connect()
        try {
            return client.query(`select * from ${funcName}`, params)
        } catch (error) {
            console.log(error)
            return false
        }
    }

    async procedure(procName: string, params?: any) {
        const client = await this._pool.connect()
        try {
            return client.query(`call ${procName}`, params)
        } catch (error) {
            console.log(error)
            return false
        }
    }
}
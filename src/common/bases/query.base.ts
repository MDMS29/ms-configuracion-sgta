export class BaseQuery<T, U> {
    public database: T
    // public dao: U
    constructor(TDatabase: new () => T) {
        this.database = new TDatabase()
        // this.dao = new TDao()

        // this.daos()
    }

    daos() { }

}

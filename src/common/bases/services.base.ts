export class BaseService<T> {
    public query: T
    
    constructor(TQuery: new () => T) {
        this.query = new TQuery()

        this.querys()
    }

    querys() { }

}
import 'vitest'

declare module 'vitest' {
    export interface ProvidedContext {
        PIC_URL: string;
    }
    interface TestContext {
        inject(key: string): unknown
    }
}
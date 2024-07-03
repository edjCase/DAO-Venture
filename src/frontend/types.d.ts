import 'vitest'

declare module 'vitest' {
    export interface ProvidedContext {
        PIC_URL: string;
        inject(key: string): string;
    }
}
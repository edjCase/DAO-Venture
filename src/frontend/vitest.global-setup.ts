import type { GlobalSetupContext } from 'vitest/node';
import { PocketIcServer } from '@hadronous/pic';


let pic: PocketIcServer | undefined;

export async function setup(ctx: GlobalSetupContext): Promise<void> {
    pic = await PocketIcServer.start();
    const url = pic.getUrl();

    (ctx as any).provide('PIC_URL', url);
    process.env.LOCAL_NETWORK_PORT = url.split(':')[2].split('/')[0];
}

export async function teardown(): Promise<void> {
    await pic?.stop();
}
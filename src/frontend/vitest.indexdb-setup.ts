import 'fake-indexeddb/auto';


// let db;

// beforeEach(async () => {
//     db = await new Promise((resolve, reject) => {
//         const request = indexedDB.open('TestDatabase', 1);
//         request.onerror = () => reject(request.error);
//         request.onsuccess = () => resolve(request.result);
//     });
// });

// afterEach(() => {
//     db.close();
// });
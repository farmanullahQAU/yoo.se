const admin = require("firebase-admin");
const functions = require("firebase-functions");
admin.initializeApp(functions.config().firebase);
let db = admin.firestore();
const groupColName = 'groups';

const leaveAllGroups = async (uid) => {
    return db.collection(groupColName).where('members', 'array-contains', uid).get().then((snapshot) => {
       let batch = db.batch();
        snapshot.docs.forEach((doc) => {
            let locations = doc.data().locations;
            delete locations[uid];
            batch.update(doc.ref, {
                members: admin.firestore.FieldValue.arrayRemove(uid),
                locations: locations
            });
            });
        return batch.commit();
        }
    );
};

exports.joinGroup = functions.https.onCall(async (data, context) => {
    let {requested, password, name, lat, lon} = data;
  try {
    const doc = await db
      .collection(groupColName)
      .doc(requested)
      .get();
    if (doc.data().password === password && doc.data().members.length <= doc.data().maxMembers) {
        await leaveAllGroups(context.auth.uid);
      const users = {};
      users[context.auth.uid] = {
        lat: lat,
        lon: lon,
        lastSeen: admin.firestore.FieldValue.serverTimestamp(),
        name: name.toString(),
        uid: context.auth.uid
      };
      let newData = {
        members: admin.firestore.FieldValue.arrayUnion(context.auth.uid),
        locations: users
      };

      await db
        .collection(groupColName)
        .doc(requested)
        .set(newData, { merge: true });
      return doc.data();
    } else {
      return null;
    }
  } catch (e) {
    return console.log(e);
  }
});

exports.scheduledFunction = functions.pubsub.schedule('every 1 hour').onRun((context) => {
    return db.collection(groupColName).where('deletion', '<=', Date.now()).getRef().then(ref =>
        console.log(ref)
    );
});

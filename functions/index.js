const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

/**
 * Cloud Function qui s'exécute automatiquement
 * quand un nouveau véhicule est créé
 * @param {object} snap - Document snapshot
 * @param {object} context - Event context
 * @return {Promise} Result of the operation
 */
exports.checkAlertsOnNewVehicle = functions.firestore
    .document("vehicles/{vehicleId}")
    .onCreate(async (snap, context) => {
        try {
            const vehicle = snap.data();
            const vehicleId = context.params.vehicleId;

            console.log("✅ Nouveau véhicule détecté:", vehicleId);
            const vehicleInfo = "Marque: " + vehicle.brand +
                ", Modèle: " + vehicle.model + ", Prix: " + vehicle.price;
            console.log("📋", vehicleInfo);

            // Récupérer toutes les alertes actives
            const alertsSnapshot = await db
                .collection("alerts")
                .where("isActive", "==", true)
                .get();

            const alertCount = alertsSnapshot.size + " alertes actives";
            console.log("🔔", alertCount);

            if (alertsSnapshot.empty) {
                console.log("⚠️ Aucune alerte active");
                return null;
            }

            const batch = db.batch();
            let notificationsCount = 0;

            // Vérifier chaque alerte
            for (const alertDoc of alertsSnapshot.docs) {
                const alert = alertDoc.data();

                console.log("🔍 Vérification alerte:", alert.title);

                // Vérifier si le véhicule correspond aux critères
                if (matchesAlert(vehicle, alert)) {
                    const match = "Correspondance pour: " + alert.title;
                    console.log("✅", match);

                    // Créer une notification
                    const notificationRef = db
                        .collection("notifications").doc();
                    const images = vehicle.images;
                    const firstImage = images && images.length > 0 ?
                        images[0] : null;
                    const notification = {
                        userId: alert.userId,
                        vehicleId: vehicleId,
                        alertId: alertDoc.id,
                        alertTitle: alert.title,
                        vehicleTitle: vehicle.brand + " " + vehicle.model,
                        vehicleBrand: vehicle.brand,
                        vehicleModel: vehicle.model,
                        vehiclePrice: vehicle.price,
                        vehicleYear: vehicle.year,
                        vehicleImageUrl: firstImage,
                        vehicleCity: vehicle.city || null,
                        createdAt: admin.firestore
                            .FieldValue.serverTimestamp(),
                        read: false,
                    };

                    batch.set(notificationRef, notification);
                    notificationsCount++;

                    // Mettre à jour lastTriggered
                    batch.update(alertDoc.ref, {
                        lastTriggered: admin.firestore
                            .FieldValue.serverTimestamp(),
                        triggeredCount: admin.firestore
                            .FieldValue.increment(1),
                    });

                    // Envoyer une notification push
                    await sendPushNotification(alert.userId, notification);
                } else {
                    console.log("❌ Pas de correspondance:", alert.title);
                }
            }

            // Sauvegarder toutes les notifications
            await batch.commit();

            const result = notificationsCount + " notification(s) créée(s)";
            console.log("🎉", result);
            return {success: true, notificationsCount: notificationsCount};
        } catch (error) {
            console.error("❌ Erreur:", error);
            return {success: false, error: error.message};
        }
    });

/**
 * Vérifie si un véhicule correspond aux critères d'une alerte
 * @param {object} vehicle - Vehicle data
 * @param {object} alert - Alert criteria
 * @return {boolean} True if matches
 */
function matchesAlert(vehicle, alert) {
    console.log("🔍 Critères de correspondance:");

    // Vérifier les marques
    if (alert.brands && alert.brands.length > 0) {
        const brandMatch = alert.brands.includes(vehicle.brand);
        const brandsStr = alert.brands.join(", ");
        const msg = "Marques: " + vehicle.brand + " in [" +
            brandsStr + "] = " + brandMatch;
        console.log("  -", msg);
        if (!brandMatch) return false;
    }

    // Vérifier les modèles
    if (alert.models && alert.models.length > 0) {
        const modelMatch = alert.models.includes(vehicle.model);
        const modelsStr = alert.models.join(", ");
        const msg = "Modèles: " + vehicle.model + " in [" +
            modelsStr + "] = " + modelMatch;
        console.log("  -", msg);
        if (!modelMatch) return false;
    }

    // Vérifier le prix minimum
    if (alert.minPrice && vehicle.price < alert.minPrice) {
        const msg = "Prix min: " + vehicle.price + " < " +
            alert.minPrice + " = false";
        console.log("  -", msg);
        return false;
    }

    // Vérifier le prix maximum
    if (alert.maxPrice && vehicle.price > alert.maxPrice) {
        const msg = "Prix max: " + vehicle.price + " > " +
            alert.maxPrice + " = false";
        console.log("  -", msg);
        return false;
    }

    // Vérifier l'année minimum
    if (alert.minYear && vehicle.year < alert.minYear) {
        const msg = "Année min: " + vehicle.year + " < " +
            alert.minYear + " = false";
        console.log("  -", msg);
        return false;
    }

    // Vérifier l'année maximum
    if (alert.maxYear && vehicle.year > alert.maxYear) {
        const msg = "Année max: " + vehicle.year + " > " +
            alert.maxYear + " = false";
        console.log("  -", msg);
        return false;
    }

    // Vérifier le kilométrage maximum
    if (alert.maxKilometers && vehicle.kilometers > alert.maxKilometers) {
        const msg = "Km max: " + vehicle.kilometers + " > " +
            alert.maxKilometers + " = false";
        console.log("  -", msg);
        return false;
    }

    // Vérifier la ville
    if (alert.city && vehicle.city !== alert.city) {
        const msg = "Ville: " + vehicle.city + " !== " +
            alert.city + " = false";
        console.log("  -", msg);
        return false;
    }

    // Vérifier le type de carburant
    if (alert.fuelTypes && alert.fuelTypes.length > 0) {
        const fuelMatch = alert.fuelTypes.includes(vehicle.fuelType);
        const fuelsStr = alert.fuelTypes.join(", ");
        const msg = "Carburant: " + vehicle.fuelType + " in [" +
            fuelsStr + "] = " + fuelMatch;
        console.log("  -", msg);
        if (!fuelMatch) return false;
    }

    // Vérifier la condition
    if (alert.conditions && alert.conditions.length > 0) {
        const condMatch = alert.conditions.includes(vehicle.condition);
        const condsStr = alert.conditions.join(", ");
        const msg = "Condition: " + vehicle.condition + " in [" +
            condsStr + "] = " + condMatch;
        console.log("  -", msg);
        if (!condMatch) return false;
    }

    // Vérifier la transmission
    if (alert.transmissions && alert.transmissions.length > 0) {
        const transMatch = alert.transmissions
            .includes(vehicle.transmission);
        const transStr = alert.transmissions.join(", ");
        const msg = "Transmission: " + vehicle.transmission +
            " in [" + transStr + "] = " + transMatch;
        console.log("  -", msg);
        if (!transMatch) return false;
    }

    console.log("✅ Toutes les conditions sont satisfaites!");
    return true;
}

/**
 * Envoie une notification push via FCM
 * @param {string} userId - User ID
 * @param {object} notification - Notification data
 * @return {Promise} Result of the operation
 */
async function sendPushNotification(userId, notification) {
    try {
        // Récupérer le token FCM de l'utilisateur
        const tokenDoc = await db.collection("fcm_tokens")
            .doc(userId).get();

        if (!tokenDoc.exists) {
            console.log("⚠️ Pas de token FCM pour:", userId);
            return;
        }

        const token = tokenDoc.data().token;

        const message = {
            notification: {
                title: "🚗 Nouvelle annonce !",
                body: notification.vehicleTitle + " - " +
                    notification.vehiclePrice + " TND",
            },
            data: {
                vehicleId: notification.vehicleId,
                alertId: notification.alertId,
                type: "new_vehicle_alert",
            },
            token: token,
        };

        await admin.messaging().send(message);
        console.log("✅ Notification push envoyée à:", userId);
    } catch (error) {
        console.error("❌ Erreur notification push:", error);
    }
}

/**
 * Fonction pour tester manuellement les alertes
 * @param {object} req - Request object
 * @param {object} res - Response object
 * @return {Promise} Result of the operation
 */
exports.testAlerts = functions.https.onRequest(async (req, res) => {
    try {
        const vehiclesSnapshot = await db.collection("vehicles")
            .limit(1).get();

        if (vehiclesSnapshot.empty) {
            return res.status(404).json({error: "Aucun véhicule trouvé"});
        }

        const vehicle = vehiclesSnapshot.docs[0].data();
        const vehicleId = vehiclesSnapshot.docs[0].id;

        const alertsSnapshot = await db.collection("alerts")
            .where("isActive", "==", true).get();

        const results = [];

        for (const alertDoc of alertsSnapshot.docs) {
            const alert = alertDoc.data();
            const matches = matchesAlert(vehicle, alert);

            results.push({
                alertId: alertDoc.id,
                alertTitle: alert.title,
                matches: matches,
                vehicle: {
                    brand: vehicle.brand,
                    model: vehicle.model,
                    price: vehicle.price,
                    year: vehicle.year,
                },
            });
        }

        res.json({
            success: true,
            vehicleId: vehicleId,
            alertsChecked: alertsSnapshot.size,
            results: results,
        });
    } catch (error) {
        console.error("Erreur:", error);
        res.status(500).json({error: error.message});
    }
});
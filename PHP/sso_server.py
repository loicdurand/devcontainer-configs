from flask import Flask, request, jsonify, redirect
from ldap3 import Server, Connection, ALL
from jose import jwt

app = Flask(__name__)

# Config LDAP
LDAP_SERVER = 'ldap://lldap:3890'  # Remplace par l'URL de ton LDAP 
LDAP_USER_DN = 'cn=admin,dc=gendarmerie,dc=defense,dc=gouv,dc=fr'  # DN de l'admin LDAP
LDAP_PASSWORD = 'my_password'  # Mot de passe admin
LDAP_BASE_DN = 'dc=gendarmerie,dc=defense,dc=gouv,dc=fr'  # Base DN de ton annuaire

# Clé secrète pour JWT
SECRET_KEY = '876a490cbae8d2275b3f401763ac6f89562f82ea85f3a5b60b710e289f1a45dd'  # Change ça pour une vraie clé en prod !

# Page de login simulée
@app.route('/login', methods=['GET', 'POST']) 
def login():
    # @TODO: définir redirect_uri dans la requête GET 
    # @TODO: rediriger vers redirect_uri en passant le token en paramètre
    # @TODO: si échec d'auth, raffraichir la page avec message d'erreur 
    if request.method == 'GET':
        # Simule un formulaire de login
        return '''
            <style>
                body {
                    font-family: Arial, sans-serif;
                    background-color: #f0f2f5;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    height: 100vh;
                    margin: 0;
                }
                .login-container {
                    background-color: white;
                    padding: 2rem;
                    border-radius: 8px;
                    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
                    width: 100%;
                    max-width: 400px;
                    text-align: center;
                }
                h2 {
                    color: #333;
                    margin-bottom: 1.5rem;
                }
                input[type="text"], input[type="password"] {
                    width: 100%;
                    padding: 0.75rem;
                    margin: 0.5rem 0;
                    border: 1px solid #ccc;
                    border-radius: 4px;
                    font-size: 1rem;
                }
                input[type="submit"] {
                    width: 100%;
                    padding: 0.75rem;
                    background-color: #007bff;
                    color: white;
                    border: none;
                    border-radius: 4px;
                    font-size: 1rem;
                    cursor: pointer;
                    transition: background-color 0.3s;
                }
                input[type="submit"]:hover {
                    background-color: #0056b3;
                }
                input[type="hidden"] {
                    display: none;
                }
                @media (max-width: 500px) {
                    .login-container {
                        padding: 1rem;
                        margin: 0 1rem;
                    }
                }
            </style>
            <form method="post">
                <input type="text" name="username" placeholder="Username"><br>
                <input type="password" name="password" placeholder="Password"><br>
                <input type="hidden" name="redirect_uri" value="http://localhost:5000/validate">
                <input type="submit" value="Login">
            </form>
        '''
    
    # Vérification des identifiants
    username = request.form.get('username')
    password = request.form.get('password')
    redirect_uri = request.form.get('redirect_uri')

    # AJOUT DEBUG: Afficher les valeurs reçues du formulaire
    print("=== DEBUG LOGIN ===")
    print(f"Username reçu: '{username}'")
    print(f"Password reçu: '{password}' (masqué pour sécurité, mais longueur: {len(password) if password else 0})")
    print(f"Redirect URI: '{redirect_uri}'")

    # Connexion au LDAP
    try:
        print("Tentative de connexion LDAP...")
        server = Server(LDAP_SERVER, get_info=ALL)
        # Construction du DN pour l'utilisateur avec ou=people
        user_dn = f'uid={username},ou=people,{LDAP_BASE_DN}'
        print(f"DN construit pour connexion: '{user_dn}'")
        conn = Connection(server, user=user_dn, password=password)
        print(conn)
        print("Connexion LDAP créée, tentative de bind...")
        if conn.bind():
            print("BIND LDAP réussi ! Génération du token JWT...")
            # Authentification réussie, générer un token JWT
            token = jwt.encode({'sub': username, 'role': 'user'}, SECRET_KEY, algorithm='HS256')
            conn.unbind()
            print(f"Token généré: {token[:50]}... (tronqué pour sécurité)")
            return redirect(f'{redirect_uri}?token={token}')
        else:
            print("BIND LDAP échoué: credentials invalides.")
            return jsonify({'error': 'Invalid credentials'}), 401
    except Exception as e:
        print(f"ERREUR LDAP: {str(e)}")
        # Optionnel: pour plus de détails sur l'exception
        import traceback
        traceback.print_exc()  # Affiche la stack trace complète
        return jsonify({'error': str(e)}), 500

# Endpoint pour vérifier le token (optionnel, pour l'app cliente)
@app.route('/validate', methods=['POST'])
def validate_token():
    token = request.json.get('token')
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
        return jsonify({'valid': True, 'payload': payload})
    except:
        return jsonify({'valid': False}), 401

if __name__ == '__main__':
    app.run(port=5000, debug=True)
from flask import Flask, request, jsonify, redirect, make_response
from ldap3 import Server, Connection, ALL, SUBTREE
from jose import jwt
import base64

app = Flask(__name__)

# Config LDAP
LDAP_SERVER = 'ldap://lldap:3890'  # URL de ton LDAP
LDAP_USER_DN = 'uid=admin,ou=people,dc=gendarmerie,dc=defense,dc=gouv,dc=fr'  # DN de l'admin LDAP
LDAP_PASSWORD = 'my_password'  # Mot de passe admin
LDAP_BASE_DN = 'dc=gendarmerie,dc=defense,dc=gouv,dc=fr'  # Base DN de ton annuaire

# Clé secrète pour JWT
SECRET_KEY = '876a490cbae8d2275b3f401763ac6f89562f82ea85f3a5b60b710e289f1a45dd'  # Change ça pour une vraie clé en prod !

# Attributs à récupérer
ATTRIBUTES = ['memberOf', 'mail', 'employeeType', 'responsabilite', 'displayname', 'givenName', 'nigend', 'specialite', 'title', 'dptUnite', 'uid', 'codeUnitesSup', 'sn']

# Attributs à récupérer pour les groupes
GROUP_ATTRIBUTES = ['codeunite', 'displayname']

# Page de login simulée
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'GET':
        # Récupérer redirect_uri depuis le paramètre url (encodé en base64)
        redirect_uri = None
        try:
            encoded_url = request.args.get('url')
            if encoded_url:
                redirect_uri = base64.b64decode(encoded_url).decode('utf-8')
                print(f"Redirect URI décodé: '{redirect_uri}'")
            else:
                redirect_uri = 'http://localhost:5000/validate'  # Valeur par défaut si pas de paramètre url
        except Exception as e:
            print(f"Erreur lors du décodage de redirect_uri: {str(e)}")
            return jsonify({'error': 'Invalid redirect_uri'}), 400

        # Simule un formulaire de login
        style = '''
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
        '''
        return '''
            <style>
                {}
            </style>
            <form method="post">
                <input type="text" name="username" placeholder="Username"><br>
                <input type="password" name="password" placeholder="Password" value="my_password"><br>
                <input type="hidden" name="redirect_uri" value="{}">
                <input type="submit" value="Login">
            </form>
        '''.format(style, redirect_uri)
    
    # Vérification des identifiants
    username = request.form.get('username')
    password = request.form.get('password')
    redirect_uri = request.form.get('redirect_uri')

    # AJOUT DEBUG: Afficher les valeurs reçues du formulaire
    print("=== DEBUG LOGIN ===")
    print(f"Username reçu: '{username}'")
    print(f"Password reçu: (masqué pour sécurité, longueur: {len(password) if password else 0})")
    print(f"Redirect URI: '{redirect_uri}'")

    # Connexion au LDAP avec l'admin
    try:
        print(f"Tentative de connexion au serveur LDAP: {LDAP_SERVER} avec admin")
        server = Server(LDAP_SERVER, get_info=ALL)
        conn = Connection(server, user=LDAP_USER_DN, password=LDAP_PASSWORD)
        print(f"Connexion admin créée, tentative de bind avec DN: '{LDAP_USER_DN}'")
        if not conn.bind():
            print(f"BIND admin échoué: {conn.result}")
            return jsonify({'error': 'Admin bind failed', 'ldap_error': str(conn.result)}), 500

        # Recherche de l'utilisateur
        print(f"Recherche de l'utilisateur: uid={username}")
        conn.search(
            search_base=f'ou=people,{LDAP_BASE_DN}',
            search_filter=f'(uid={username})',
            search_scope=SUBTREE,
            attributes=ATTRIBUTES  # Récupérer les attributs personnalisés
        )
        if not conn.entries:
            print(f"Utilisateur '{username}' non trouvé dans ou=people,{LDAP_BASE_DN}")
            conn.unbind()
            return jsonify({'error': 'User not found'}), 401

        # Récupérer le DN de l'utilisateur
        user_dn = conn.entries[0].entry_dn
        print(f"DN de l'utilisateur trouvé: '{user_dn}'")

        # Tenter un bind avec les credentials de l'utilisateur
        print(f"Tentative de bind avec l'utilisateur: '{user_dn}'")
        user_conn = Connection(server, user=user_dn, password=password)
        if user_conn.bind():
            print("BIND utilisateur réussi ! Génération du token JWT...")
            # Récupérer les attributs pour le JWT
            user_attributes = {attr: conn.entries[0][attr].value for attr in ATTRIBUTES if attr in conn.entries[0]}

            # Récupérer les attributs de groupe via memberOf
            if 'memberOf' in user_attributes:
                member_of = user_attributes["memberOf"]  # Liste des DN des groupes
                print(f"Groupes trouvés (memberOf): {member_of}")
                for group_dn in member_of:
                    conn.search(
                        search_base=group_dn,
                        search_filter='(objectClass=*)',
                        search_scope=SUBTREE,
                        attributes=GROUP_ATTRIBUTES
                    )
                    if conn.entries :
                        group_data = {attr: conn.entries[0][attr].value for attr in GROUP_ATTRIBUTES if attr in conn.entries[0]}
                        if group_data['codeunite'] is not None:
                            group_attrs= group_data
                            print(f"Attributs du groupe {group_dn}: {group_data}")
                    else:
                        print(f"Aucun attribut trouvé pour le groupe {group_dn}")

            # Authentification réussie, générer un token JWT avec les attributs
            token = jwt.encode({
                'sub': username,
                'role': 'user',
                'attributes': user_attributes,  # Inclure les attributs personnalisés
                'group_attrs': group_attrs
            }, SECRET_KEY, algorithm='HS256')
            user_conn.unbind()
            conn.unbind()
            print(f"Token généré: {token[:50]}... (tronqué pour sécurité)")
            # Créer une réponse avec un cookie
            response = make_response(redirect(redirect_uri))
            response.set_cookie('lldap', token, httponly=True, secure=False)  # secure=True en prod avec HTTPS
            return response
        else:
            print(f"BIND utilisateur échoué: {user_conn.result}")
            conn.unbind()
            return jsonify({'error': 'Invalid credentials', 'ldap_error': str(user_conn.result)}), 401

    except Exception as e:
        print(f"ERREUR LDAP: {str(e)}")
        import traceback
        traceback.print_exc()  # Affiche la stack trace complète
        return jsonify({'error': str(e)}), 500

# Endpoint pour vérifier le token
@app.route('/validate', methods=['GET'])
def validate_token():
    token = request.args.get('id')
    if not token:
        return jsonify({'valid': False, 'error': 'No token provided'}), 400
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
        return jsonify({
            'valid': True,
            'user_data': payload['attributes'],
            'group_data': payload['group_attrs']  # Inclure les attributs des groupes (ou, unite)
        })
    except:
        return jsonify({'valid': False, 'error': 'Invalid token'}), 401

if __name__ == '__main__':
    app.run(port=5000, debug=True)
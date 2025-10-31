<?php

## IMPORTANT NOTE!
## Replace any instance of /srv/www/server with the real path on your server!

# Check if the given password meets all strength requirements
# Feel free to modify the strength requirements according to your threat model
function is_password_strong($password) {
    if (strlen($password) < 10) {
        return "Password must be at least 10 characters long.";
    }
    if (!preg_match('/[A-Z]/', $password)) {
        return "Password must contain at least one uppercase letter.";
    }
    if (!preg_match('/[a-z]/', $password)) {
        return "Password must contain at least one lowercase letter.";
    }
    if (!preg_match('/\d/', $password)) {
        return "Password must contain at least one digit.";
    }
    if (!preg_match('/[\W_]/', $password)) {
        return "Password must contain at least one special character.";
    }

    $weak = ['1234', 'password', 'letmein', 'admin', 'qwerty'];
    foreach ($weak as $bad) {
        if (stripos($password, $bad) !== false) {
            return "Password is too common or weak.";
        }
    }

    return true;
}

# User registration logic
if ($_SERVER["REQUEST_METHOD"] === "POST") {
    # Username must be all lowercase, because otherwise Windows clients will get confused when logging in
    $username = strtolower(trim($_POST["username"] ?? ''));
    $password = trim($_POST["password"] ?? '');

    # Do not allow account registration if password is weak
    $result = is_password_strong($password);
    if ($result !== true) {
        die("Invalid password: $result");
    }

    $clean_username = htmlspecialchars($username, ENT_QUOTES);

    $salt = bin2hex(random_bytes(16));
    $hashed_password = crypt($password, '$6$' . $salt);
    
    $userfile = '/srv/www/server/data/users.list';
    if (file_exists($userfile)) {
        $lines = file($userfile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        foreach ($lines as $line) {
            if (strpos($line, $clean_username . ':') === 0) {
                die("Username already taken. Choose another.");
            }
        }
    }

    # Make sure the newly registered user is put in the list of registrated users
    $line_users_txt = $clean_username . ':' . $hashed_password . PHP_EOL;
    file_put_contents($userfile, $line_users_txt, FILE_APPEND | LOCK_EX);

    # Put the user registration request in a queue
    $line = "# smbusrauthd-register-req" . PHP_EOL . $clean_username . ':' . $password . PHP_EOL;
    $id = uniqid("cred_", true);
    $filepath = "/srv/www/server/data/queue/{$id}.rgs";
    file_put_contents($filepath, $line, LOCK_EX);

    echo "Registration successful! Account will be created shortly (max 1 minute).";
} else {
    echo "Invalid request method.";
}
?>

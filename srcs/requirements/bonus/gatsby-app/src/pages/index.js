import React from "react";
import "../styles/CVStyles.css";

const CVPage = () => {
  return (
    <div className="container">
      <header className="header">
        <h1 className="name">Claudio Rea</h1>
        <p className="role">Junior Software Engineer</p>
        <a href="https://github.com/Nihilantropy" className="link">
          Visit My GitHub Profile
        </a>
      </header>
      <main className="main">
        <section className="section">
          <h2 className="sectionTitle">Formation</h2>
          <p>
            <strong>42 School of Rome</strong> (almost completed). Check out one
            of my exciting projects:{" "}
            <a
              href="https://github.com/Nihilantropy/FidesChallenge"
              className="projectLink"
            >
              Fides Challenge
            </a>{" "}
            - A challenge aimed at creating a full microservices application
            using Docker and Kubernetes.
          </p>
        </section>

        <section className="section">
          <h2 className="sectionTitle">Other Background Studies</h2>
          <p>
            I hold a Philosophy degree from{" "}
            <strong>Università La Sapienza of Rome</strong>. Although
            non-technical, this background has shaped my critical thinking,
            creativity, and problem-solving skills.
          </p>
        </section>

        <section className="section">
          <h2 className="sectionTitle">Professional Experience</h2>
          <p>
            I have several professional experiences outside the IT industry,
            which helped me develop a strong work ethic, effective teamwork,
            and valuable soft skills.
          </p>
        </section>

        <section className="section">
          <h2 className="sectionTitle">Curiosity</h2>
          <p>
            I'm a passionate video game enthusiast and regularly participate in
            game jams. I'm also an associate of the Spaghetti Studio Game Club.
            Explore the source code of my latest game project, built using
            Godot:{" "}
            <a
              href="https://github.com/Nihilantropy/SpaghettiStudioGameJame2024"
              className="projectLink"
            >
              Spaghetti Studio Game Jam 2024
            </a>.
          </p>
          <p className="buttonContainer">
            <a href="https://crea.42.it/alien-eggs/AlienEggs.html" className="gameButton">
              Test My Last Game
            </a>
          </p>
        </section>
      </main>
      <footer className="footer">
        <p>© 2025 Claudio Rea. Built with Gatsby.js</p>
      </footer>
    </div>
  );
};

export default CVPage;

class App extends preact.Component {
  constructor(props) {
    super(props);
    this.state = {
      loading: false,
      title: "",
      name: "",
      job: "",
      company: "",
      date: "",
      logo: "",
      url: "",
      titleValid: "background-color: none",
      nameValid: "background-color: none",
      jobValid: "background-color: none",
      companyValid: "background-color: none",
      dateValid: "background-color: none",
      logoValid: "background-color: none",
      urlStyle: "display:none",
      submit: true
    };

    this.update = this.update.bind(this);
    this.createPres = this.createPres.bind(this);
    this.clearContent = this.clearContent.bind(this);
    this.validate = this.validate.bind(this);
  }


  update(field, field2) {
    return e => this.setState({
      [field]: e.currentTarget.value,
      [field2]: "background-color: none",
    })
  }

  createPres(e) {
    e.preventDefault();
    
    const validate = this.validate()
    if (validate) {
      this.setState({ "loading": true });
      fetch('http://localhost:5000/post', {
        method: "POST",
        body: JSON.stringify(this.state),
        headers: { "Content-type": "application/json; charset=UTF-8" }
      })
        .then(response => response.json())
        .then(json => json.presentationURL === 'undefined' ? "" : this.setState({
          'url': json.presentationURL,
          "loading": false,
          'urlStyle': "display:block",
          'submit': "false"
        }))
        .catch(err => console.log(err));
    }

  }

  clearContent() {
    return this.setState({
      'loading': "false",
      'title': "",
      'name': "",
      'job': "",
      'company': "",
      'date': "",
      'logo': "",
      'url': "",
      'titleValid': "background-color: none",
      'nameValid': "background-color: none",
      'jobValid': "background-color: none",
      'companyValid': "background-color: none",
      'dateValid': "background-color: none",
      'logoValid': "background-color: none",
      'urlStyle': "display:none",
      'submit': true
    })
  };

  validate() {
    this.state.title.length === 0 ? this.setState({ 'titleValid': "background-color: coral" }) : null
    this.state.name.length === 0 ? this.setState({ 'nameValid': "background-color: coral" }) : null
    this.state.job.length === 0 ? this.setState({ 'jobValid': "background-color: coral" }) : null
    this.state.company.length === 0 ? this.setState({ 'companyValid': "background-color: coral" }) : null
    this.state.date.length === 0 ? this.setState({ 'dateValid': "background-color: coral" }) : null
    this.state.logo.length === 0 ? this.setState({ 'logoValid': "background-color: coral" }) : null
    return this.state.title
      && this.state.name
      && this.state.job
      && this.state.company
      && this.state.date
      && this.state.logo
  }

  loggedin() {
    fetch('http://localhost:5000/login', {
      method: "GET",
      headers: { "Content-type": "application/json; charset=UTF-8" }
    })
      .then(response => response.json())

      .then(
        json => console.log(json)
      )
  }



  render() {
    
    return (
      this.state.loading === true ? <Loader /> :
        <div id="form_container">
          <div id="col_flexer">
            <form id="app_form" onSubmit={this.createPres}>
              <h1>Slide Creator</h1>
              <br />
              <label>Presentation Title:
                <br />
                <input type="text" value={this.state.title} onChange={this.update('title', 'titleValid')} style={this.state.titleValid} />
              </label>
              <br />

              <label>Name:
                <br />
                <input type="text" value={this.state.name} onChange={this.update('name', 'nameValid')} style={this.state.nameValid} />
              </label>
              <br />

              <label>Job Title:
                <br />
                <input type="text" value={this.state.job} onChange={this.update('job', 'jobValid')} style={this.state.jobValid} />
              </label>
              <br />

              <label>Company Name:
                <br />
                <input type="text" value={this.state.company} onChange={this.update('company', 'companyValid')} style={this.state.companyValid} />
              </label>
              <br />

              <label>Date:
                <br />
                <input type="date" value={this.state.date} onChange={this.update('date', 'dateValid')} style={this.state.dateValid} />
              </label>
              <br />

              <label>Company Site URL:
                <br />
                <input type="text" value={this.state.logo} placeholder="(i.e. google.com)" onChange={this.update('logo', 'logoValid')} style={this.state.logoValid} />
              </label>
              <br />
              <br />
              <div id={this.state.submit === true ? "submit_container" : "submit_hide"}>
                <button id='submit' type='submit' style="width: 100px">Create Slide</button>
              </div>
              <br />
              <br />
              <a id='url' href={this.state.url} style={this.state.urlStyle} target="_blank">Check out your new slide!</a>
              <br />

              <br />
            </form>
            
            <button id={this.state.url.length === 0 ? "clearContentHide" : "clearContentShow"} onClick={this.clearContent}>New Presentation</button>
          </div>
        </div>
    );
  }
};


const Loader = () => <div id="gif-container"><img src="/loading.gif"></img></div>

